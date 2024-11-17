#!/bin/bash

LOG_FILE="network_status.log"
EMAIL_TO="YOUR_GMAIL_EMAIL"

send_email() {
    local node=$1
    local status=$2
    echo "Enviando e-mail para $EMAIL_TO sobre o status de $node"
    if ! echo -e "Subject: Alerta de Conectividade: $node\n\nO nó $node está $status em $(date)." | msmtp "$EMAIL_TO"; then
        echo "$(date): Erro ao enviar e-mail para $node" >> "$LOG_FILE"
    else
        echo "$(date): E-mail enviado para $node" >> "$LOG_FILE"
    fi
}

monitor_node() {
    local node=$1
    echo "Monitorando $node"
    if ping -c 1 -W 2 "$node" > /dev/null; then
        echo "$(date): $node está acessível" >> "$LOG_FILE"
    else
        echo "$(date): $node está inacessível" >> "$LOG_FILE"
        send_email "$node" "inacessível"
    fi
}

monitor_aws_nodes() {
    local AWS_NODES=("$@")
    echo "Monitorando AWS Nodes:"
    for node in "${AWS_NODES[@]}"; do
        monitor_node "$node"
    done
}

monitor_gcp_nodes() {
    local GCP_NODES=("$@")
    echo "Monitorando GCP Nodes:"
    for node in "${GCP_NODES[@]}"; do
        monitor_node "$node"
    done
}

get_aws_nodes() {
    AWS_NODES=$(aws ec2 describe-instances --query 'Reservations[].Instances[].PublicIpAddress' --output text)
    echo "$AWS_NODES"
}

get_gcp_nodes() {
    GCP_NODES=$(gcloud compute instances list --format="value(EXTERNAL_IP)")
    echo "$GCP_NODES"
}

AWS_NODES=($(get_aws_nodes))
GCP_NODES=($(get_gcp_nodes))

echo "AWS Nodes: ${AWS_NODES[@]}"
echo "GCP Nodes: ${GCP_NODES[@]}"

while true; do
    monitor_aws_nodes "${AWS_NODES[@]}"
    monitor_gcp_nodes "${GCP_NODES[@]}"
    sleep 60
done
