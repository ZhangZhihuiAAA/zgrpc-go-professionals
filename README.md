# zgrpc-go-professionals

## Resources used in this project:
### Non-Standard Library Go modules/packages:
* #### Protobuf Wellknown Types:
    * google.golang.org/protobuf/types/known/timestamppb
    * google.golang.org/protobuf/types/known/fieldmaskpb
* #### Protobuf Reflection: google.golang.org/protobuf/reflect/protoreflect
* #### Validating GRPC Requests: github.com/envoyproxy/protoc-gen-validate/validate (go install)
* #### GRPC Packages: google.golang.org/grpc
    * Credentials: google.golang.org/grpc/credentials
    * Metadata: google.golang.org/grpc/metadata
    * Server Reflection: google.golang.org/grpc/reflection
    * Error Handling: google.golang.org/grpc/codes, google.golang.org/grpc/status
* #### GRPC Middlewares:
    * github.com/grpc-ecosystem/go-grpc-middleware/providers/prometheus
    * github.com/grpc-ecosystem/go-grpc-middleware/v2/interceptors/auth
    * github.com/grpc-ecosystem/go-grpc-middleware/v2/interceptors/logging
    * github.com/grpc-ecosystem/go-grpc-middleware/v2/interceptors/ratelimit
    * github.com/grpc-ecosystem/go-grpc-middleware/v2/interceptors/retry
* #### GRPC Unit Testing: google.golang.org/grpc/test/bufconn

* #### Tracing API Calls: 
    * github.com/prometheus/client_golang/prometheus
    * github.com/prometheus/client_golang/prometheus/promhttp
    * go.opentelemetry.io/contrib/instrumentation/google.golang.org/grpc/otelgrpc
### Tools:
* #### VSCode
* #### Makefile
* #### protoc
* #### Docker
* #### kubectl
* #### kind (CLI for creating k8s clusters)
* #### k9s (GUI tool for k8s operations)
* #### grpcurl (CLI for interating with GRPC servers; used for debugging)
* #### ghz (CLI for GRPC benchmarking and load testing)
* #### Envoy (Proxy for GRPC server side load balancing)
* #### func-e (CLI for Running Envoy)
