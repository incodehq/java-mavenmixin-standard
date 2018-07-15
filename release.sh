RELEASE_VERSION=$1
shift
SNAPSHOT_VERSION=$1
shift
KEYID=$1
shift
PASSPHRASE=$*

if [ ! "$RELEASE_VERSION" -o ! "$SNAPSHOT_VERSION" -o ! "$KEYID" -o ! "$PASSPHRASE" ]; then
    echo "usage: $(basename $0) [release_version] [snapshot_version] [keyid] [passphrase]" >&2
    exit 1
fi


echo ""
echo "sanity check (mvn clean package -o)"
echo ""
mvn clean package -Dskip.mavenmixin-standard -o >/dev/null
if [ $? != 0 ]; then
    echo "... failed" >&2
    exit 1
fi


echo ""
echo "bumping version to $RELEASE_VERSION"
echo ""
sh ./bumpver.sh $RELEASE_VERSION
if [ $? != 0 ]; then
    echo "... failed" >&2
    exit 1
fi


echo ""
echo "double-check (mvn clean package -o)"
echo ""
mvn clean package -Dskip.mavenmixin-standard -o >/dev/null
if [ $? != 0 ]; then
    echo "... failed" >&2
    exit 1
fi


echo ""
echo "releasing 'mixin' module (mvn clean deploy)"
echo ""
mvn clean deploy -Psonatyperelease -Dskip.mavenmixin-standard -Dpgp.secretkey=keyring:id=$KEYID -Dpgp.passphrase="literal:$PASSPHRASE"
if [ $? != 0 ]; then
    echo "... failed" >&2
    exit 1
fi



echo ""
echo "bumping version to $SNAPSHOT_VERSION"
echo ""
sh ./bumpver.sh $SNAPSHOT_VERSION
if [ $? != 0 ]; then
    echo "... failed" >&2
    exit 1
fi


echo ""
echo "now run:"
echo ""
echo "git push origin master && git push origin $RELEASE_VERSION"
echo ""
