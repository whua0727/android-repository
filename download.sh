#!/bin/bash

# automate the update of studio version, i.e. 1.0.1 at the moment
# TODO clean obsolete sdk manager and studio

# XXX no need to mirror gradle, https://services.gradle.org/distributions/gradle-2.1-bin.zip
# it doesn't download when internet is unavailable, and android studio works just fine

rm -f orig/sdk/index.html
wget http://developer.android.com/sdk/index.html \
                             -P orig/sdk

# sed remove lines until
# http://www.linuxquestions.org/questions/linux-newbie-8/how-to-use-sed-to-delete-all-lines-before-the-first-match-of-a-pattern-802069/
# sed remove lines after
# http://stackoverflow.com/questions/5227295/how-do-i-delete-all-lines-in-a-file-starting-from-after-a-matching-line
sed -n '/pax/,$p' -i orig/sdk/index.html
sed '/end pax/q' -i orig/sdk/index.html

#grep -Po 'https://dl.google.com/dl/android/studio/install/1.0.1/[^"]*' orig/sdk/index.html | wget -N -P dl/android/studio/install/1.0.1 -c -i -
#grep -Po 'https://dl.google.com/dl/android/studio/ide-zips/1.0.1/[^"]*' orig/sdk/index.html | wget -N -P dl/android/studio/ide-zips/1.0.1 -c -i -
grep -Po 'https://dl.google.com/dl/android/studio/[^"]*' orig/sdk/index.html > \
                                dl/android/studio/download.sh
sed -i -r 's/https:(\/\/dl.google.com\/(dl\/android\/studio\/[^\/]+\/[^\/]+)\/.+)/wget -N -P \2 -c http:\1/g' \
                                dl/android/studio/download.sh
sh dl/android/studio/download.sh
grep -Po 'http://dl.google.com/android/[^"]*' orig/sdk/index.html | \
                    wget -N -P android -c -i -

sed '/<!-- insert -->/q' sdk/template.html > sdk/index.html.tmp
cat orig/sdk/index.html | \
    sed 's/https:\/\/dl.google.com//g' | \
    sed 's/http:\/\/dl.google.com//g' | \
    sed 's/onclick="return onDownload(this)"/target="_blank"/g' >> \
         sdk/index.html.tmp
sed -n '/<!-- insert -->/,$p' sdk/template.html >> \
         sdk/index.html.tmp
mv sdk/index.html.tmp sdk/index.html

# requires 25GB

# http://stackoverflow.com/questions/242538/unix-shell-script-find-out-which-directory-the-script-file-resides
BASEDIR=$(dirname $0)

$BASEDIR/sync-index.sh

$BASEDIR/manage.sh

# clean obsolete sdk packages
grep true packages.csv | grep -Po '(?<=https://dl-ssl[.]google[.]com/)[^,]+|(?<=https://dl[.]google[.]com/)[^,]+' | sed -r 's/^(.*)$/rm -f \1/g' > clean-obsolete.sh
sh clean-obsolete.sh

# http://stackoverflow.com/questions/8535947/xslt-2-0-transformation-via-linux-shell
java -jar $BASEDIR/saxon.jar orig/android/repository/extras/intel/addon.xml \
                         $BASEDIR/android/repository/extras/intel/addon.xsl | \
                       sed 's/https:/http:/g' | \
                       wget -N -P android/repository/extras/intel -c -i -
java -jar $BASEDIR/saxon.jar orig/android/repository/addon-6.xml \
                         $BASEDIR/android/repository/addon-6.xsl | \
                       sed 's/https:/http:/g' | \
                       wget -N -P android/repository -c -i -
java -jar $BASEDIR/saxon.jar orig/android/repository/sys-img/android-tv/sys-img.xml \
                         $BASEDIR/android/repository/sys-img/android-tv/sys-img.xsl | \
                       sed 's/https:/http:/g' | \
                       wget -N -P android/repository/sys-img/android-tv -c -i -
java -jar $BASEDIR/saxon.jar orig/android/repository/repository-10.xml \
                         $BASEDIR/android/repository/repository-10.xsl | \
                       sed 's/https:/http:/g' | \
                       wget -N -P android/repository -c -i -
java -jar $BASEDIR/saxon.jar orig/android/repository/sys-img/android-wear/sys-img.xml \
                         $BASEDIR/android/repository/sys-img/android-wear/sys-img.xsl | \
                       sed 's/https:/http:/g' | \
                       wget -N -P android/repository/sys-img/android-wear -c -i -
java -jar $BASEDIR/saxon.jar orig/android/repository/addon.xml \
                         $BASEDIR/android/repository/addon.xsl | \
                       sed 's/https:/http:/g' | \
                       wget -N -P android/repository -c -i -
java -jar $BASEDIR/saxon.jar orig/android/repository/addon.xml \
                         $BASEDIR/android/repository/addon.admob.xsl | \
                       sed 's/https:/http:/g' | \
                       wget -N -P googleadmobadssdk -c -i -
java -jar $BASEDIR/saxon.jar orig/android/repository/addon.xml \
                         $BASEDIR/android/repository/addon.analytics.xsl | \
                       sed 's/https:/http:/g' | \
                       wget -N -P gaformobileapps -c -i -
java -jar $BASEDIR/saxon.jar orig/android/repository/sys-img/x86/addon-x86.xml \
                         $BASEDIR/android/repository/sys-img/x86/addon-x86.xsl | \
                       sed 's/https:/http:/g' | \
                       wget -N -P android/repository/sys-img/x86 -c -i -
java -jar $BASEDIR/saxon.jar orig/android/repository/sys-img/google_apis/sys-img.xml \
                         $BASEDIR/android/repository/sys-img/google_apis/sys-img.xsl | \
                       sed 's/https:/http:/g' | \
                       wget -N -P android/repository/sys-img/google_apis -c -i -
java -jar $BASEDIR/saxon.jar orig/android/repository/sys-img/android/sys-img.xml \
                         $BASEDIR/android/repository/sys-img/android/sys-img.xsl | \
                       sed 's/https:/http:/g' | \
                       wget -N -P android/repository/sys-img/android -c -i -
java -jar $BASEDIR/saxon.jar orig/glass/gdk/addon.xml \
                         $BASEDIR/glass/gdk/addon.xe22.xsl | \
                       sed 's/https:/http:/g' | \
                       wget -N -P glass/xe22 -c -i -

# make urls relative and local
sed 's/https:\/\/dl-ssl.google.com//g' \
    orig/android/repository/addons_list-2.xml > \
         android/repository/addons_list-2.xml
sed 's/https:\/\/dl-ssl.google.com//g' \
    orig/android/repository/extras/intel/addon.xml > \
         android/repository/extras/intel/addon.xml
sed 's/https:\/\/dl-ssl.google.com//g' \
    orig/android/repository/addon-6.xml > \
         android/repository/addon-6.xml
sed 's/https:\/\/dl-ssl.google.com//g' \
    orig/android/repository/sys-img/android-tv/sys-img.xml > \
         android/repository/sys-img/android-tv/sys-img.xml
sed 's/https:\/\/dl-ssl.google.com/http:\/\/studyjams.dushu.hu/g' \
    orig/android/repository/repository-10.xml > \
         android/repository/repository-10.xml
sed 's/https:\/\/dl-ssl.google.com//g' \
    orig/android/repository/sys-img/android-wear/sys-img.xml > \
         android/repository/sys-img/android-wear/sys-img.xml
cat orig/android/repository/addon.xml | \
    sed 's/https:\/\/dl-ssl.google.com/http:\/\/studyjams.dushu.hu/g' | \
    sed 's/https:\/\/dl.google.com/http:\/\/studyjams.dushu.hu/g' > \
         android/repository/addon.xml
sed 's/https:\/\/dl-ssl.google.com//g' \
    orig/android/repository/sys-img/x86/addon-x86.xml > \
         android/repository/sys-img/x86/addon-x86.xml
sed 's/https:\/\/dl-ssl.google.com//g' \
    orig/android/repository/sys-img/google_apis/sys-img.xml > \
         android/repository/sys-img/google_apis/sys-img.xml
sed 's/https:\/\/dl-ssl.google.com/http:\/\/studyjams.dushu.hu/g' \
    orig/android/repository/sys-img/android/sys-img.xml > \
         android/repository/sys-img/android/sys-img.xml
sed 's/https:\/\/dl.google.com/http:\/\/studyjams.dushu.hu/g' \
    orig/glass/gdk/addon.xml > \
         glass/gdk/addon.xml

# verify
grep -Prn '<sdk:url>' * --include=*.xml --exclude-dir=orig | grep http
