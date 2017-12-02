const pick = require('lodash.pick')
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

const validQueries = {
  typeOfForm: 'Type of Form',
  divisions: 'Divisions/Groups',
  functions: 'Functions',
  firstApprover: 'First Approver',
  secondApprover: 'Second Approver (if required)',
  thirdApprover: 'Third Approver (if required)',
  finalApprover: 'Final Approver (if required)',
  link: 'Link',
  typeOfExpense: 'Types of Expenses'
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

const buildQuery = query => {
  const validKeys = Object.keys(validQueries)
  const selectedQueries = pick(query, validKeys)

  return Object.keys(selectedQueries).map(queryKey => {
    return {
      match: {
        [validQueries[queryKey]]: {
          query: selectedQueries[queryKey]
        }
      }
    }
  })
}

fastify.get('/', async (request, reply) => {
  const results = await search({
    match_all: {}
  })
  reply.send(selectData(results))
})

fastify.get('/search/:term', async (request, reply) => {
  const term = request.params.term
  const must = buildQuery(request.query)
  const results = await search({
    bool: {
      should: [
        {
          multi_match: {
            query: term,
            fields: ['*']
          }
        }
      ],
      must
    }
  })
  reply.send(selectData(results))
})

fastify.listen(3000, err => {
  if (err) throw err
  console.log(`server listening on ${fastify.server.address().port}`)
})
