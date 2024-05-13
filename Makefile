protocv1:
	protoc --go_out=. \
	       --go_opt=paths=source_relative \
	       --go-grpc_out=. \
	       --go-grpc_opt=paths=source_relative \
	       proto/todo/v1/*.proto

importdir=proto
module=zgrpc-go-professionals
protoc:
	protoc --proto_path=$(importdir) \
	       --go_out=. \
	       --go_opt=module=$(module) \
	       --go-grpc_out=. \
	       --go-grpc_opt=module=$(module) \
	       --validate_out="lang=go,module=$(module):." \
	       proto/todo/v2/*.proto

srvaddr=0.0.0.0:50051
metricsaddr=0.0.0.0:50052
runs:
	go run ./server $(srvaddr) $(metricsaddr)
runs_grpclogson:
	GRPC_GO_LOG_SEVERITY_LEVEL=info go run ./server $(srvaddr) $(metricsaddr)
runc:
	go run ./client $(srvaddr)

dbuilds:
	docker build --no-cache -t zgrpc-go-professionals:server -f server.dockerfile .

dbuildc:
	docker build --no-cache -t zgrpc-go-professionals:client -f client.dockerfile .

dbuilde:
	docker build --no-cache -t zgrpc-go-professionals:envoy-proxy -f envoy.dockerfile .

kloads:
	kind load docker-image zgrpc-go-professionals:server

kloadc:
	kind load docker-image zgrpc-go-professionals:client

kloade:
	kind load docker-image zgrpc-go-professionals:envoy-proxy

kapplys:
	kubectl apply -f k8s/server.yaml

kapplyc:
	kubectl apply -f k8s/client.yaml

kapplye:
	kubectl apply -f envoy/service.yaml
	kubectl apply -f envoy/deployment.yaml

kcreatec:
	kind create cluster --config k8s/kind.yaml -v

kdeletec:
	kind delete cluster

utest:
	go test -run Test -v -count=1 ./server

ltest:
	ghz --proto ./proto/todo/v2/todo.proto \
	    --import-paths=proto \
	    --call todo.v2.TodoService.AddTask \
	    --data '{"description": "task"}' \
	    --cacert ./certs/ca_cert.pem \
	    --cname "check.test.example.com" \
	    --metadata '{"auth_token": "authd"}' \
	    $(srvaddr)

gcurl:
	grpcurl -cacert ./certs/ca_cert.pem \
	        -authority "check.test.example.com" \
	        -reflect-header 'auth_token: authd' \
	        $(srvaddr) $(args)

gcurld:
	grpcurl -cacert ./certs/ca_cert.pem \
	        -authority "check.test.example.com" \
	        -reflect-header 'auth_token: authd' \
	        -rpc-header 'auth_token: authd' \
	        -d $(data) \
	        $(srvaddr) $(args)

.PHONY: protocv1 protoc runs runs_grpclogson runc dbuilds dbuildc dbuilde \
	    kloads kloadc kloade kapplys kapplyc kapplye kcreatec kdeletec \
	    utest ltest gcurl gcurld