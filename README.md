# Personal Link Page

I wanted a linktree like page but with my own domain and automated deployment with the cheapest method possible (s3 bucket). With S3 you also [pay per 1k requests](https://aws.amazon.com/s3/pricing/), with that we put cloudflare in front to prevent ddos and paying for more than you anticipated.

## How does it work

![pic](linktree.png)

We have github actions in the background listening for events pushed to the main branch, when you make a push it will deploy the infrastructure. 

## How to get started

### AWS

We need to create a policy that allows github to make changes to your aws account. We will go with the policy of least privilege. Here are the services we need access to and the changes we need to make



### Github

Clone the repository and there's a few values to change.

### Cloudflare

## Thanks

Shoutout to [Sylwia Vargas](https://github.com/sylwiavargas/Tech-Writing-Linktree) for the base code