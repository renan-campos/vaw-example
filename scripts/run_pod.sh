# Creates and runs the https server in minikube.
source $(dirname $0)/keys.sh

image="vaw-example"
tag=$(date +%a-%H-%M-%S)
pod="vaw-example"

eval $(minikube docker-env)

docker build -t $image:$tag .

oc delete pod/$pod
oc run --image $image:$tag $pod

echo "Wait 5 seconds for server to start."
sleep 5
echo "Server started, port-forwarding to localhost:8080."
echo "Look at https://localhost:8080 on your browser."
oc port-forward pod/vaw-example 8080:9000
