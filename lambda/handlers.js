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
  _instanceState({ callback, method, dataTransform })
}

// Stop instance
exports.stop = (_event, _context, callback) => {
  const method = 'stopInstances'
  const dataTransform = toStateChangeReport('StoppingInstances')
  _instanceState({ callback, method, dataTransform })
}

// Get instance status
exports.status = (_event, _context, callback) => {
  const method = 'describeInstanceStatus'
  const dataTransform = toStatusReport
  const methodParams = { IncludeAllInstances: true }
  _instanceState({ callback, method, methodParams, dataTransform })
}

async function _instanceState ({
  callback,
  method,
  methodParams = {},
  dataTransform = (data) => data
}) {
  const {
    INSTANCE_ID: instanceId,
    SNS_TOPIC_ARN: snsTopicArn,
    SNS_MESSAGE: snsMessage
  } = process.env

  aws.config.update({region: 'us-east-1'})
  const params = {
    ...methodParams,
    InstanceIds: [ instanceId ]
  }

  try {
    const ec2Result = await new aws.EC2()[method](params).promise()

    // Send SNS message if provided
    try {
      if (snsTopicArn && snsMessage) {
        const snsResult = await new aws.SNS()
          .publish({
            TopicArn: snsTopicArn,
            Subject: snsMessage,
            Message: snsMessage
          })
          .promise()
        console.log('Successfully sent SNS message:', snsResult)
      }
    } catch (error) {
      console.error('Failed to send SNS message:', error)
    }

    const statusCode = 200
    const body = dataTransform(ec2Result)
    console.log(body)
    callback(null, { statusCode, body })
  } catch (error) {
    console.error(error)
    callback(new Error(error))
  }
}
