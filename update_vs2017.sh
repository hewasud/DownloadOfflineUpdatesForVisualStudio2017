VSDIR=/cygdrive/c/vs2017
DDIR=/cygdrive/d/delta

#OVSDIR=/cygdrive/c/vs2017.old

# cp -r vs2017 /cygdrive/c/vs2017.old
# rsync -r $VSDIR $OVSDIR

# call update on /cygdrive/c/vs2017
#$VSDIR/vs_setup.exe --layout $VSDIR

#get newest vs_setup
cd /cygdrive/c
rm -f vs_enterprise.exe
wget https://aka.ms/vs/15/release/vs_enterprise.exe
chmod +x vs_enterprise.exe
/cygdrive/c/vs_enterprise.exe --layout 'c:\vs2017'



if [[ -e $DDIR ]]; then
	rm -rf $DDIR/*
else
	mkdir $DDIR
fi

cd $VSDIR
find . -type f -mtime -1 -exec cp --parents \{\} $DDIR \;
cd -

#tar vcf - $DDIR |gzip -9 > ${DDIR}.tgz
#rm -rf $DDIR/*
#cd /cygdrive/c/

cd /cygdrive/c/users/hewasud/Downloads
rm delta.*
7z a -r -v1g -bsp1 -- delta d\:\\delta

echo "Starting web server to allow download of delta.tgz"
python -m http.server
cd -
