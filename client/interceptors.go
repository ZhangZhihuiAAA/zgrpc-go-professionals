package main

import (
	"context"

	"google.golang.org/grpc"
	"google.golang.org/grpc/metadata"
)

const (
    authTokenKey   string = "auth_token"
    authTokenValue string = "authd"
)

// unaryAuthInterceptor is an interceptor automatically adding the auth token to a request.
func unaryAuthInterceptor(ctx context.Context, method string, req, reply any, cc *grpc.ClientConn, invoker grpc.UnaryInvoker, opts ...grpc.CallOption) error {
    ctx = metadata.AppendToOutgoingContext(ctx, authTokenKey, authTokenValue)
    err := invoker(ctx, method, req, reply, cc, opts...)

    return err
}

// streamAuthInterceptor is an interceptor automatically adding the auth token to a request.
func streamAuthInterceptor(ctx context.Context, desc *grpc.StreamDesc, cc *grpc.ClientConn, method string, streamer grpc.Streamer, opts ...grpc.CallOption) (grpc.ClientStream, error) {
    ctx = metadata.AppendToOutgoingContext(ctx, authTokenKey, authTokenValue)
    s, err := streamer(ctx, desc, cc, method, opts...)

    if err != nil {
        return nil, err
    }

    return s, nil
}