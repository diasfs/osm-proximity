const path = require("path")
const fs = require("fs")
const Geohash = require('ngeohash');

//const pois = require(path.join(__dirname, "brasil.poi.json"))
const pois = "/data/brasil.poi.json"
const data_folder = path.join(path.dirname(__dirname),'poi-data')

fs.mkdirSync(data_folder, { recursive: true })

let levels = [4, 5, 6]

for (let { properties: { osm_id: id, name, other_tags }, geometry: { coordinates: [lng, lat] } } of pois.features) {
    let tags = other_tags.replace(/\"/igm, '').replace(/\=\>/igm, ':');
    for (let level of levels) {
        let geohash = Geohash.encode(lat, lng, level)
        let folder = path.join(data_folder, `${level}`)
        fs.mkdirSync(folder, { recursive: true })
        let filename = path.join(folder, `${geohash}.json`)
        let data = []
        if (fs.existsSync(filename)) {
            try {
                data = require(filename)
            } catch (err) {
                data = []
            }
        }
        let row = data.find(d => d.id == id)
        if (!row) {
            data.push({
                id,
                name,
                tags,
                lat,
                lng
            })

            fs.writeFileSync(filename, JSON.stringify(data))
        }
    }
}