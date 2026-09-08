#!/bin/bash

cd /boot/grub
rm grubenv
grub-editenv grubenv create
grub-editenv grubenv set default=0
update-grub