package main

import (
	"context"
	"log"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
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

// unaryLogInterceptor logs the endpoints being called.
func unaryLogInterceptor(ctx context.Context, req any, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (any, error) {
    log.Println(info.FullMethod, "called")
    return handler(ctx, req)
}

// streamLogInterceptor logs the endpoints being called.
func streamLogInterceptor(srv any, ss grpc.ServerStream, info *grpc.StreamServerInfo, handler grpc.StreamHandler) error {
    log.Println(info.FullMethod, "called")
    return handler(srv, ss)
}