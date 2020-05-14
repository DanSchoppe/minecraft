var aws = require('aws-sdk')

const toStateChangeReport = (topKey) => (data) => {
  const previousState = data[topKey][0].PreviousState.Name
  const currentState = data[topKey][0].CurrentState.Name
  return `${previousState} -> ${currentState}`
}
const toStatusReport = (data) => data.InstanceStatuses[0].InstanceState.Name

// Start instance
exports.start = (_event, _context, callback) => {
  const method = 'startInstances'
  const dataTransform = toStateChangeReport('StartingInstances')
  return _instanceState({ callback, method, dataTransform })
}

// Stop instance
exports.stop = (_event, _context, callback) => {
  const method = 'stopInstances'
  const dataTransform = toStateChangeReport('StoppingInstances')
  return _instanceState({ callback, method, dataTransform })
}

// Get instance status
exports.status = (_event, _context, callback) => {
  const method = 'describeInstanceStatus'
  const dataTransform = toStatusReport
  const methodParams = { IncludeAllInstances: true }
  return _instanceState({ callback, method, methodParams, dataTransform })
}

const _instanceState = ({
  callback,
  method,
  methodParams = {},
  dataTransform = (data) => data
}) => {
  const instanceId = process.env.INSTANCE_ID
  if (!instanceId) {
    const error = 'No instanceId provided'
    console.error(error)
    return callback(new Error(error))
  }

  aws.config.update({region: 'us-east-1'})
  const params = {
    ...methodParams,
    InstanceIds: [ instanceId ]
  }

  new aws.EC2()[method](params, function(error, data) {
    if (error) {
      console.error(error)
      callback(new Error(error))
      return
    }

    const statusCode = 200
    const body = dataTransform(data)
    console.log(body)
    callback(null, { statusCode, body })
  })
}
