#!/usr/bin/env bash
openssl req -nodes -newkey rsa:4096 -keyout example.com.key -out example.com.csr -subj "/C=BD/ST=Dhaka/L=Dhaka/O=DevOps Engineers Ltd. /OU=RND/CN=example.com"
openssl x509 -req -in example.com.csr -signkey example.com.key -out example.com.crt
