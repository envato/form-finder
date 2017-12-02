const fastify = require('fastify')()
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

const getIndices = async () => {
  return CLIENT.cat.indices({ v: true })
}

const search = async (query, opts = {}) => {
  return CLIENT.search({
    index: INDEX,
    body: {
      size: opts.size || 20,
      from: opts.from || 0,
      query
    }
  })
}

const selectData = results => results.hits.hits.map(result => result._source)

fastify.get('/', async (request, reply) => {
  const results = await search({
    match_all: {}
  })
  reply.send(selectData(results))
})

fastify.get('/search/:term', async (request, reply) => {
  const term = request.params.term
  const results = await search({
    multi_match: {
      query: term,
      fields: ['*']
    }
  })
  reply.send(selectData(results))
})

fastify.listen(3000, err => {
  if (err) throw err
  console.log(`server listening on ${fastify.server.address().port}`)
})
