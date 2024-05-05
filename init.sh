dir=$(dirname $(realpath ${BASH_SOURCE[0]}))

# Create project folders
mkdir server client proto certs k8s
mkdir -p proto/todo/v1 proto/todo/v2

# Go init server module
cd $dir/server; go mod init github.com/ZhangZhihuiAAA/zgrpc-go-professionals/server

# Go init client module
cd $dir/client; go mod init github.com/ZhangZhihuiAAA/zgrpc-go-professionals/client

# Go init proto module
cd $dir/proto; go mod init github.com/ZhangZhihuiAAA/zgrpc-go-professionals/proto

# Dowload certs
# cd $dir/certs
# curl https://github.com/grpc/grpc-go/tree/master/examples/data/x509/server_cert.pem --output server_cert.pem
# curl https://github.com/grpc/grpc-go/tree/master/examples/data/x509/server_key.pem --output server_key.pem
# curl https://github.com/grpc/grpc-go/tree/master/examples/data/x509/ca_cert.pem --output ca_cert.pem

cd $dir