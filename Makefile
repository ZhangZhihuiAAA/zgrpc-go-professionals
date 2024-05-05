protocv1:
	protoc --go_out=. \
	       --go_opt=paths=source_relative \
	       --go-grpc_out=. \
	       --go-grpc_opt=paths=source_relative \
	       proto/todo/v1/*.proto

protoc:
	protoc --go_out=pb \
	       --go_opt=module=zgrpc-go-professionals/pb \
	       --go-grpc_out=pb \
	       --go-grpc_opt=module=zgrpc-go-professionals/pb \
	       proto/todo/v2/*.proto

srvaddr=0.0.0.0:50051
runserver:
	go run ./server $(srvaddr)
runclient:
	go run ./client $(srvaddr)

dbuild:
	docker build -t zgrpc-go-professionals:server .

create_cluster:
	kind create cluster --config k8s/kind.yaml
delete_cluster:
	kind delete cluster

.PHONY: protocv1 protoc runserver runclient dbuild_server create_cluster delete_cluster protocm