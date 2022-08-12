#!/bin/bash
#apt update -y && apt install osmctools -y

PBF_FILENAME=/data/brasil-latest.osm.pbf
NEW_PBF_FILENAME=/data/brasil-latest-new.osm.pbf
UPDATE_URL=download.geofabrik.de/south-america/brazil-updates
DOWNLOAD_URL=http://download.geofabrik.de/south-america/brazil-latest.osm.pbf

OSM_NODES_FILENAME=/data/brasil.nodes.osm
OSM_POI_FILENAME=/data/brasil.poi.osm
JSON_FILENAME=/data/brasil.poi.json

if [ -f "$PBF_FILENAME" ]; then
    # update the existing
    echo "UPDATING $PBF_FILENAME"
    ls /data -lha
    osmupdate "$PBF_FILENAME" "$NEW_PBF_FILENAME" --base-url="$UPDATE_URL"
    if [ -f "$NEW_PBF_FILENAME"]; then
        rm -f "$PBF_FILENAME"
        mv "$NEW_PBF_FILENAME" "$PBF_FILENAME"
    else
        echo "NO UPDATES AVAILABLE"
    fi
else
    #  download the latest
    echo "DOWNLOADING $DOWNLOAD_URL TO $PBF_FILENAME"
    wget "$DOWNLOAD_URL" -O "$PBF_FILENAME"
fi

echo "READING $PBF_FILENAME"
osmosis --read-pbf "$PBF_FILENAME" --tf accept-nodes aeroway=aerodrome amenity=atm,bank,bar,bus_station,cafe,car_wash,grave_yard,pharmacy,hospital,library,post_depot,nightclub,parking,police,post_office,school,childcare,university,restaurant craft=bakery shop=beauty,books,convenience,chemist,pet,mall,supermarket landuse=cemetery building=church,stadium leisure=fitness_centre,sports_centre,park,stadium tourism=museum,attraction public_transport=station --tf reject-ways --tf reject-relations --write-xml "$OSM_NODES_FILENAME"

echo "CONVERTING $OSM_NODES_FILENAME TO $OSM_POI_FILENAME"
osmconvert "$OSM_NODES_FILENAME" --drop-ways --drop-author --drop-relations --drop-versions > "$OSM_POI_FILENAME"

echo "CONVERTING $OSM_POI_FILENAME TO $JSON_FILENAME"
ogr2ogr -f GeoJSON "$JSON_FILENAME" "$OSM_POI_FILENAME" points