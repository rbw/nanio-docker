#!/usr/bin/env bash

bash pull_app.sh

cd app
npm install && npm run build
rm -rf ../static && mv build ../static
rm -rf node_modules

echo "built latest version of UI..."

