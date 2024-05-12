package main

import (
	"context"
	"log"
	"net"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	pb "zgrpc-go-professionals/pb/todo/v2"

	"golang.org/x/sync/errgroup"
	"golang.org/x/time/rate"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
	"google.golang.org/grpc/reflection"

	//_ "google.golang.org/grpc/encoding/gzip"

	grpcprom "github.com/grpc-ecosystem/go-grpc-middleware/providers/prometheus"
	"github.com/grpc-ecosystem/go-grpc-middleware/v2/interceptors/auth"
	"github.com/grpc-ecosystem/go-grpc-middleware/v2/interceptors/logging"
	"github.com/grpc-ecosystem/go-grpc-middleware/v2/interceptors/ratelimit"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"go.opentelemetry.io/contrib/instrumentation/google.golang.org/grpc/otelgrpc"
)

func newMetrisServer(httpAddr string, reg *prometheus.Registry) *http.Server {
    m := http.NewServeMux()
    m.Handle("/metrics", promhttp.HandlerFor(reg, promhttp.HandlerOpts{}))
    httpSrv := &http.Server{
        Addr: httpAddr,
        Handler: m,
    }

    return httpSrv
}

func newGrpcServer(srvMetrics *grpcprom.ServerMetrics) (*grpc.Server, error) {
    creds, err := credentials.NewServerTLSFromFile("./certs/server_cert.pem", "./certs/server_key.pem")
    if err != nil {
        return nil, err
    }

    logger := log.New(os.Stderr, "", log.Ldate|log.Ltime)
    limiter := &simpleLimiter{
        limiter: rate.NewLimiter(5, 10),
    }

    opts := []grpc.ServerOption{
        grpc.Creds(creds),
        grpc.StatsHandler(otelgrpc.NewServerHandler()),
        grpc.ChainUnaryInterceptor(
            ratelimit.UnaryServerInterceptor(limiter),
            srvMetrics.UnaryServerInterceptor(),
            auth.UnaryServerInterceptor(validateAuthToken),
            logging.UnaryServerInterceptor(logCalls(logger)),
        ),
        grpc.ChainStreamInterceptor(
            ratelimit.StreamServerInterceptor(limiter),
            srvMetrics.StreamServerInterceptor(),
            auth.StreamServerInterceptor(validateAuthToken),
            logging.StreamServerInterceptor(logCalls(logger)),
        ),
    }
    s := grpc.NewServer(opts...)

    pb.RegisterTodoServiceServer(s, &server{
        d: NewDb(),
    })
    reflection.Register(s)

    return s, nil
}

func main() {
    args := os.Args[1:]

    if len(args) == 0 {
        log.Fatalln("usage: server [GRPC_IP_ADDR] [METRICS_IP_ADDR]")
    }

    grpcAddr := args[0]
    httpAddr := args[1]

    ctx, cancel := context.WithCancel(context.Background())
    defer cancel()

    // handle CTRL+C
    quit := make(chan os.Signal, 1)
    signal.Notify(quit, os.Interrupt, syscall.SIGTERM)
    defer signal.Stop(quit)

    g, ctx := errgroup.WithContext(ctx)

    srvMetrics := grpcprom.NewServerMetrics(
        grpcprom.WithServerHandlingTimeHistogram(
            grpcprom.WithHistogramBuckets([]float64{0.001, 0.01, 0.1, 0.3, 0.6, 1, 3, 6, 9, 20, 30, 60, 90, 120}),
        ),
    )
    reg := prometheus.NewRegistry()
    reg.MustRegister(srvMetrics)

    lis, err := net.Listen("tcp", grpcAddr)
    if err != nil {
        log.Fatalf("failed to listen: %v\n", err)
    }

    grpcServer, err := newGrpcServer(srvMetrics)
    if err != nil {
        log.Fatalf("unexpected error: %v", err)
    }

    g.Go(func() error {
        log.Printf("gRPC server listening at %s\n", grpcAddr)
        if err := grpcServer.Serve(lis); err != nil {
            log.Printf("failed to start gRPC server: %v\n", err)
            return err
        }
        log.Println("gRPC server shutdown")
        return nil
    })

    metricsServer := newMetrisServer(httpAddr, reg)
    g.Go(func() error {
        log.Printf("metrics server listening at %s\n", httpAddr)
        if err := metricsServer.ListenAndServe(); err != nil && err != http.ErrServerClosed {
            log.Printf("failed to serve metrics: %v\n", err)
            return err
        }
        log.Println("metrics server shutdown")
        return nil
    })

    // handle termination
    select {
    case <-quit:
        break
    case <-ctx.Done():
        break
    }

    // gracefully shutdown servers
    cancel()

    timeoutCtx, timeoutCancel := context.WithTimeout(context.Background(), 10 * time.Second)
    defer timeoutCancel()

    log.Println("shuting down servers, please wait...")

    grpcServer.GracefulStop()
    metricsServer.Shutdown(timeoutCtx)

    // wait for shutdown
    if err := g.Wait(); err != nil {
        log.Fatal(err)
    }
}