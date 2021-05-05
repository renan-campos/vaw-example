source $(dirname $0)/keys.sh

# Run server:
echo "Running https server..."
go run server.go
