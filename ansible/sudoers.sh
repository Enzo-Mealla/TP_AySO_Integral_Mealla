#!/bin/bash

USUARIO=$(whoami)

sudo usermod -aG sudo "$USUARIO"
