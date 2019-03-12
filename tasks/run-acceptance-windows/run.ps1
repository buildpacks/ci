docker load -i packs-samples-image\image
docker tag "$(cat packs-samples-image/image-id)" "packs/samples:dev"

docker load -i packs-build-image\image
docker tag "$(cat packs-build-image/image-id)" "packs/build:dev"

docker load -i packs-run-image\image
docker tag "$(cat packs-run-image/image-id)" "packs/run:dev"

docker load -i golang-image\image
docker tag "$(cat golang-image/image-id)" "golang"

$env:PACK_PATH="$pwd\pack-windows-binary\pack"
$env:PACK_TAG="dev"

cd pack-repo
"PACK_TAG=dev" -e "PACK_PATH=..\pack-windows-binary\pack" -v "$pack_path":/tmp/pack golang go test -mod=vendor -tags=acceptance -v -count=1 -parallel=1 -timeout=0 ./acceptance