# run a standalone instance
docker network create rabbits

docker run -d --rm --net rabbits --hostname rabbit-1 --name rabbit-1 rabbitmq:3.8 

docker exec -it rabbit-1 cat /var/lib/rabbitmq/.erlang.cookie

docker rm -f rabbit-1

docker run -d --rm --net rabbits -p 8081:15672 -e RABBITMQ_ERLANG_COOKIE=CFLIFBQEVELBRZMVHGPJ --hostname rabbit-1 --name rabbit-1 rabbitmq:3.8-management
docker run -d --rm --net rabbits -p 8082:15672 -e RABBITMQ_ERLANG_COOKIE=CFLIFBQEVELBRZMVHGPJ --hostname rabbit-2 --name rabbit-2 rabbitmq:3.8-management
docker run -d --rm --net rabbits -p 8083:15672 -e RABBITMQ_ERLANG_COOKIE=CFLIFBQEVELBRZMVHGPJ --hostname rabbit-3 --name rabbit-3 rabbitmq:3.8-management

docker exec -it rabbit-1 bash
rabbitmq-plugins enable rabbitmq_management
rabbitmq-plugins list

docker exec -it rabbit-2 bash
rabbitmq-plugins enable rabbitmq_management
rabbitmq-plugins list

docker exec -it rabbit-3 bash
rabbitmq-plugins enable rabbitmq_management
rabbitmq-plugins list

#join the rabbit-2, rabbit-3 to rabbit-1

#join node 2
docker exec -it rabbit-2 rabbitmqctl stop_app
docker exec -it rabbit-2 rabbitmqctl reset
docker exec -it rabbit-2 rabbitmqctl join_cluster rabbit@rabbit-1
docker exec -it rabbit-2 rabbitmqctl start_app
docker exec -it rabbit-2 rabbitmqctl cluster_status

#join node 3
docker exec -it rabbit-3 rabbitmqctl stop_app
docker exec -it rabbit-3 rabbitmqctl reset
docker exec -it rabbit-3 rabbitmqctl join_cluster rabbit@rabbit-1
docker exec -it rabbit-3 rabbitmqctl start_app
docker exec -it rabbit-3 rabbitmqctl cluster_status



#cd messaging\rabbitmq\applications\publisher
#docker build . -t aimvector/rabbitmq-publisher:v1.0.0
docker build .\messaging\rabbitmq\applications\publisher -t aimvector/rabbitmq-publisher:v1.0.0
docker run -it --rm --net rabbits -e RABBIT_HOST=rabbit-1 -e RABBIT_PORT=5672 -e RABBIT_USERNAME=guest -e RABBIT_PASSWORD=guest -p 80:80 aimvector/rabbitmq-publisher:v1.0.0
docker rm -f silly_joliot 

#cd messaging\rabbitmq\applications\consumer
#docker build . -t aimvector/rabbitmq-consumer:v1.0.0
docker build .\messaging\rabbitmq\applications\consumer -t aimvector/rabbitmq-consumer:v1.0.0
docker run -it --rm --net rabbits -e RABBIT_HOST=rabbit-1 -e RABBIT_PORT=5672 -e RABBIT_USERNAME=guest -e RABBIT_PASSWORD=guest aimvector/rabbitmq-consumer:v1.0.0

docker exec -it rabbit-1 rabbitmqctl cluster_status
docker exec -it rabbit-2 rabbitmqctl cluster_status
docker exec -it rabbit-3 rabbitmqctl cluster_status

docker rm -f rabbit-1
docker rm -f rabbit-2
docker rm -f rabbit-3

docker ps


docker run -d --rm --net rabbits `
-v ${PWD}/config/rabbit-1/:/config/ `
-e RABBITMQ_CONFIG_FILE=/config/rabbitmq `
-e RABBITMQ_ERLANG_COOKIE=CFLIFBQEVELBRZMVHGPJ `
--hostname rabbit-1 `
--name rabbit-1 `
-p 8081:15672 `
rabbitmq:3.8-management

docker run -d --rm --net rabbits `
-v ${PWD}/config/rabbit-2/:/config/ `
-e RABBITMQ_CONFIG_FILE=/config/rabbitmq `
-e RABBITMQ_ERLANG_COOKIE=CFLIFBQEVELBRZMVHGPJ `
--hostname rabbit-2 `
--name rabbit-2 `
-p 8082:15672 `
rabbitmq:3.8-management

docker run -d --rm --net rabbits `
-v ${PWD}/config/rabbit-3/:/config/ `
-e RABBITMQ_CONFIG_FILE=/config/rabbitmq `
-e RABBITMQ_ERLANG_COOKIE=CFLIFBQEVELBRZMVHGPJ `
--hostname rabbit-3 `
--name rabbit-3 `
-p 8083:15672 `
rabbitmq:3.8-management

#NODE 1 : MANAGEMENT http://localhost:8081
#NODE 2 : MANAGEMENT http://localhost:8082
#NODE 3 : MANAGEMENT http://localhost:8083

# enable federation plugin
rabbitmq-plugins enable rabbitmq_federation
rabbitmq-plugins list 

docker exec -it rabbit-1 bash

docker exec -it rabbit-1 rabbitmq-plugins enable rabbitmq_federation 
docker exec -it rabbit-2 rabbitmq-plugins enable rabbitmq_federation
docker exec -it rabbit-3 rabbitmq-plugins enable rabbitmq_federation

docker exec -it rabbit-1 rabbitmq-plugins list
docker exec -it rabbit-2 rabbitmq-plugins list
docker exec -it rabbit-3 rabbitmq-plugins list
#docker exec -it rabbit-1 bash

# https://www.rabbitmq.com/ha.html#mirroring-arguments

docker exec -it rabbitmqctl set_policy ha-fed \
    ".*" '{"federation-upstream-set":"all", "ha-mode":"nodes", "ha-params":["rabbit@rabbit-1","rabbit@rabbit-2","rabbit@rabbit-3"]}' \
    --priority 1 \
    --apply-to queues



 docker exec -it rabbitmqctl set_policy ha-fed \
    ".*" '{"federation-upstream-set":"all", "ha-sync-mode":"automatic", "ha-mode":"nodes", "ha-params":["rabbit@rabbit-1","rabbit@rabbit-2","rabbit@rabbit-3"]}' \
    --priority 1 \
    --apply-to queues

    docker rm -f rabbit-1