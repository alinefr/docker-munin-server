#!/usr/bin/env python3
import os
import json

json_file = '/opt/gcm-trigger/devices.json'


def generate_devices(devices_str):
    devices_json = {'devices': devices_str.split()}

    with open(json_file, 'w') as outfile:
        json.dump(devices_json, outfile)

    print(f'{json_file} successfully generated')


if __name__ == "__main__":
    devices_str = os.environ.get('ANDROID_DEVICES', None)
    if devices_str:
        generate_devices(devices_str)
