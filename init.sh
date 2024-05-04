dir=$(dirname $(realpath ${BASH_SOURCE[0]}))

# Create project folders
mkdir server client proto
mkdir -p proto/todo/v1

# Go init server module
cd $dir/server; go mod init github.com/ZhangZhihuiAAA/zgrpc-go-professionals/server

# Go init client module
cd $dir/client; go mod init github.com/ZhangZhihuiAAA/zgrpc-go-professionals/client

# Go init proto module
cd $dir/proto; go mod init github.com/ZhangZhihuiAAA/zgrpc-go-professionals/proto