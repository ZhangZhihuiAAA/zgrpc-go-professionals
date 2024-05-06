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

dbuilds:
	docker build -t zgrpc-go-professionals:server -f server.dockerfile .

dbuildc:
	docker build -t zgrpc-go-professionals:client -f client.dockerfile .

kloads:
	kind load docker-image zgrpc-go-professionals:server

kloadc:
	kind load docker-image zgrpc-go-professionals:client

kapplys:
	kubectl apply -f k8s/server.yaml

kapplyc:
	kubectl apply -f k8s/client.yaml

kcreatec:
	kind create cluster --config k8s/kind.yaml -v
kdeletec:
	kind delete cluster

.PHONY: protocv1 protoc runserver runclient dbuilds dbuildc createc deletec