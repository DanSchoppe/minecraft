var aws = require('aws-sdk')

// Start instance
exports.start = (event, context) => {
  return _setInstanceState(event, context, 'startInstances')
}

// Stop instance
exports.stop = (event, context) => {
  return _setInstanceState(event, context, 'stopInstances')
}

const _setInstanceState = (event, context, method) => {
  const instanceId = process.env.INSTANCE_ID
  if (!instanceId) {
    const error = 'No instanceId provided'
    console.error(error)
    return context.fail(error)
  }

  aws.config.update({region: 'us-east-1'})
  const params = {
    InstanceIds: [ instanceId ],
  }

  new aws.EC2()[method](params, function(error, data) {
    if (error) {
      console.error(error)
      context.fail(error)
    }

    context.succeed(data)
  })
}
