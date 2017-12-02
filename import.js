const csv = require('csvtojson')
const ELASTICSEARCH = require('elasticsearch')

const Forms = `${process.env.PWD}/forms.csv`
const ESCLUSTER = 'http://localhost:9200'
const INDEX = 'envato'
const TYPE = 'forms'
const BULK = []
const CLIENT = new ELASTICSEARCH.Client({
  host: ESCLUSTER,
  apiVersion: '6.0'
})

csv()
  .fromFile(Forms)
  .on('json', obj => {
    BULK.push({ index: { _index: INDEX, _type: TYPE } }, obj)
    console.log(`Adding ${obj['Type of Form']} to array`)
  })
  .on('end', () => {
    CLIENT.bulk(
      {
        body: BULK
      },
      err => {
        if (err) console.log(err)
      }
    )

    console.log('Processing completed')
  })
