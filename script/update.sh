#! /bin/bash

export PATH=/usr/local/bin:$PATH
export RAILS_ENV="production"

t=`date +%Y/%m/%d-%H:%M:%S`
echo $t >> /home/tools/njc_bookclub/tmp/reading_overdue.log

cd "/home/tools/njc_bookclub" > /dev/null 2>&1
h=`rake -s reading:all`
echo $h >> /home/tools/njc_bookclub/tmp/reading_overdue.log

t=`date +%Y/%m/%d-%H:%M:%S`
echo $t >> /home/tools/njc_bookclub/tmp/douban_download.log

cd "/home/tools/njc_bookclub" > /dev/null 2>&1
d=`rake -s douban:all`
echo $d >> /home/tools/njc_bookclub/tmp/douban_download.log

