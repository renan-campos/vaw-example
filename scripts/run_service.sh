# Creates and runs the https server as a service in minikube.
source $(dirname $0)/keys.sh

image="vaw-example"
tag=$(date +%a-%H-%M-%S)
pod="vaw-example"

eval $(minikube docker-env)

docker build -t $image:$tag .

sed "s/IMAGE_NAME/$image:$tag/" yamls/deployment.yaml.template > yamls/deployment.yaml
oc apply -f yamls/

oc port-forward service/vaw-example 8080:9000
