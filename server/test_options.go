package main

type testOptions struct {
    isAvailable bool
}

var defaultTestOptions = testOptions{
    isAvailable: true,
}

type TestOption func(* testOptions) error

func WithIsAvailable(a bool) TestOption {
    return func(opts *testOptions) error {
        opts.isAvailable = a
        return nil
    }
}