#!/bin/bash
MAILHOST=$(drudge config mutt.host)
ssh $MAILHOST -- touch $START_MUTT
ssh $MAILHOST
