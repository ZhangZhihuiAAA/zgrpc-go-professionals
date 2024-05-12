protocv1:
	protoc --go_out=. \
	       --go_opt=paths=source_relative \
	       --go-grpc_out=. \
	       --go-grpc_opt=paths=source_relative \
	       proto/todo/v1/*.proto

importdir=proto
module=zgrpc-go-professionals/pb
outdir=pb
protoc:
	protoc --proto_path=$(importdir) \
	       --go_out=$(outdir) \
	       --go_opt=module=$(module) \
	       --go-grpc_out=$(outdir) \
	       --go-grpc_opt=module=$(module) \
	       --validate_out="lang=go,module=$(module):$(outdir)" \
	       proto/todo/v2/*.proto

srvaddr=0.0.0.0:50051
metricsaddr=0.0.0.0:50052
runs:
	go run ./server $(srvaddr) $(metricsaddr)
runc:
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

utest:
	go test -run Test -v -count=1 ./server

.PHONY: protocv1 protoc runs runc dbuilds dbuildc kloads kloadc kapplys kapplyc kcreatec kdeletec utest