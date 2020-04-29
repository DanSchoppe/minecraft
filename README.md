Minecraft server configuration and management

This project defines the necessary AWS infrastructure to host a
Minecraft server on AWS at minimal cost.

## Summary

The overall goal is to run a decent server at minimal cost. Since AWS
EC2 only charges on a minute-by-minute basis, one way to achieve this
goal is to simply shut down the server when it's unused.

This means that you want to grant players the ability to turn the
server on so they can play at their leisure. And ideally you don't
want them to be burdened with remembering to shut it down.

So how do we accomplish this?
- Host an API so the server can be turned on with a REST request
- Watch server metrics for inactivity, then shut it down
- ??
- Profit

## Infrastructure

All the infrastructure described below uses
[Terraform](https://www.terraform.io/) to describe and provision the
cloud infrastructure on AWS.

### Server Instance

The server is a compute-optimized EC2 instance with a pretty vanilla
configuration:
- running the latest Ubuntu Server AMI
- SSH keypair for remote access
- simple security group
  - SSH
  - ping
  - Internet access
  - Minecraft server ports

### API

Using AWS API Gateway, expose interfaces to control the server's
state. Players can use a GET request to start or stop the server.
- `/start`: proxied to a Lambda function to start the EC2 instance
- `/stop`: proxied to a Lambda function to stop the EC2 instance
  - Note: `/stop` isn't strictly required, as we auto-stop the instance
    on inactivity (described below)

#### Lambdas

A few dozen lines of Node to simply call
eg. `aws.EC2().startInstances(...)`. No dependencies, so building the
Lambda `.zip` artifact for deployment is as simple as putting the
single file in a `.zip` archive.

#### Custom Domain

Who wants to give out a crummy
`https://abc123.execute-api.us-east-1.amazonaws.com/start` URL to
their friends? Nah, register a domain, set up an SSL cert (for HTTPS)
and make it all professional-like. Details:
- reference a registered SSL cert from AWS Certificate Manager
  - pro tip: use [Let's Encrypt](https://letsencrypt.org/) to generate
    a free signed certificate
- map the described API to a custom subdomain

### Auto Shutdown

This part is pretty drop-dead simple. Using CloudWatch, keep an eye on
CPU utilization. If the machine is idle for awhile, shut it down.
- CloudWatch alarm monitoring for CPU utilization below 2% for ~10 minutes

## Server

So we've got the infrastructure configuration covered, but what about
the actual server? Obviously run the latest [hosting
software](https://www.minecraft.net/en-us/download/server/bedrock/),
but there's one thing we haven't yet covered:

### DNS

Well, you can make things simple and pay to reserve a static IP
address via AWS Elastic IP. Then make an `A` record with your domain
registrar to point at your instance's static IP.

But AWS potentially charges you several dollars per month for the
static IP. And who's got all that paper money :dollar: :dollar: just
sitting around? You wouldn't be reading this if you were ok with that
solution.

So what you should probably do is set up dynamic DNS on your
server. Run [ddclient](https://sourceforge.net/p/ddclient/wiki/Home/)
or equivalent to update your DNS record on every server boot. It'll
take an extra minute for clients to pick up on the latest DNS entry,
but now you can buy a whole extra coffee each month. See? [I told you
there'd be profit](#summary)

## Future

### Cloud Storage

I forgot to mention: don't accidentally terminate your EC2
instance. Your server storage would go with it. :cry:

For this reason and for flexibility / modularity, it would be nice to
dynamically load the server storage at boot and write it back to S3 at
shutdown.

This would also be a prerequisite for:

### Containerize

It might be nice to containerize the server so it's contents were
version controlled. This would enable something like an auto-scaling
service on AWS ECS rather than EC2 / CloudWatch.

## Conclusion

Host a Minecraft server. It's fun. Your friends can play the game, and
you can spend way too much time optimizing the machine they'll play it
on.
