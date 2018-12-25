#!/bin/sh
pm2 stop server || true
pm2 delete server || true
pm2 flush || true
