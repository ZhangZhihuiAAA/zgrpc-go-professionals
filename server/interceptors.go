package main

import (
	"context"
	"fmt"
	"log"

	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"

	"github.com/grpc-ecosystem/go-grpc-middleware/v2/interceptors/logging"
)

const (
    authTokenKey   string = "auth_token"
    authTokenValue string = "authd"
)

// validateAuthToken asserts that the authTokenKey is present and associated
// with authTokenValue in the current context header.
// It returns a context if the auth token is valid, otherwise it returns an error.
func validateAuthToken(ctx context.Context) (context.Context, error) {
    md, _ := metadata.FromIncomingContext(ctx)

    if t, ok := md[authTokenKey]; ok {
        switch {
        case len(t) != 1:
            return nil, status.Errorf(
                codes.InvalidArgument,
                "%s should contain only 1 value",
                authTokenKey,
            )
        case t[0] != authTokenValue:
            return nil, status.Errorf(
                codes.Unauthenticated,
                "incorrect %s",
                authTokenKey,
            )
        }
    } else {
        return nil, status.Errorf(
            codes.Unauthenticated,
            "failed to get %s",
            authTokenKey,
        )
    }

    return ctx, nil
}

const (
    grpcService = 5 // "grpc.service"
    grpcMethod  = 7 // "grpc.method"
)

// logCalls logs the endpoints being called in a service.
func logCalls(l *log.Logger) logging.Logger {
    return logging.LoggerFunc(func(_ context.Context, lvl logging.Level, msg string, fields ...any) {
        switch lvl {
        case logging.LevelDebug:
            msg = fmt.Sprintf("DEBUG: %v", msg)
        case logging.LevelInfo:
            msg = fmt.Sprintf("INFO: %v", msg)
        case logging.LevelWarn:
            msg = fmt.Sprintf("WARN: %v", msg)
        case logging.LevelError:
            msg = fmt.Sprintf("ERROR: %v", msg)
        default:
            panic(fmt.Sprintf("unknown level %v", lvl))
        }

        l.Println(msg, fields[grpcService], fields[grpcMethod])
    })
}
