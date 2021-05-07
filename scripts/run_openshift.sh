# Creates and runs the https server as a service in minikube.
# And a validation webhook that forbids secrets.
source $(dirname $0)/keys.sh

read -p "Enter repository to push image to: " image_repo

image="vaw-example"
tag=$(date +%a-%H-%M-%S)
pod="vaw-example"

eval $(minikube docker-env)

docker build -t $image_repo/$image:$tag .
docker push $image_repo/$image:$tag

sed "s|IMAGE_NAME|$image_repo/$image:$tag|" yamls/deployment.yaml.template > yamls/deployment.yaml
ENCODED_CA=$(base64 -w 0 $CA_PUBLIC)
sed "s/CA_BUNDLE/$ENCODED_CA/" yamls/webhook.yaml.template > yamls/webhook.yaml

oc apply -f yamls/
