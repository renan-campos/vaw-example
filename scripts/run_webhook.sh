# Creates and runs the https server as a service in minikube.
# And a validation webhook that forbids secrets.
source $(dirname $0)/keys.sh

image="vaw-example"
tag=$(date +%a-%H-%M-%S)
pod="vaw-example"

eval $(minikube docker-env)

docker build -t $image:$tag .

sed "s/IMAGE_NAME/$image:$tag/" yamls/deployment.yaml.template > yamls/deployment.yaml
ENCODED_CA=$(base64 -w 0 $CA_PUBLIC)
sed "s/CA_BUNDLE/$ENCODED_CA/" yamls/webhook.yaml.template > yamls/webhook.yaml

oc apply -f yamls/
