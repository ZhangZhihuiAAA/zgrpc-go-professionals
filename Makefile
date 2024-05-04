protocv1:
	protoc --go_out=. \
	       --go_opt=paths=source_relative \
	       --go-grpc_out=. \
	       --go-grpc_opt=paths=source_relative \
	       proto/todo/v1/*.proto

protoc:
	protoc --go_out=. \
	       --go_opt=paths=source_relative \
	       --go-grpc_out=. \
	       --go-grpc_opt=paths=source_relative \
	       proto/todo/v2/*.proto

srvaddr=0.0.0.0:50051
runserver:
	go run ./server $(srvaddr)
runclient:
	go run ./client $(srvaddr)

.PHONY: protocv1 protoc runserver runclient