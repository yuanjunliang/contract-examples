import dotenv from 'dotenv'
dotenv.config({})

import { utils, Contract, Bytes } from 'ethers'
import { ethers } from 'hardhat'
import { ec as EC } from 'elliptic'
import { expect } from 'chai'

const { Wallet } = ethers

const {
  keccak256,
  solidityPack,
  hexlify,
  concat,
  hexZeroPad,
  splitSignature,
  arrayify,
  randomBytes
} = utils
const PRIVATE_KEY = process.env.PRIVATE_KEY || ''
if (!PRIVATE_KEY) throw 'Please config private key in .env'

describe('test ecdsa recover without prefix sign', async () => {
  let signer
  let contract: Contract
  let data: string
  let digest: string

  beforeEach(async () => {
    signer = new Wallet(PRIVATE_KEY, ethers.provider)
    const ECDSAExample = await ethers.getContractFactory('ECDSAExample', signer)
    contract = await ECDSAExample.connect(signer).deploy()
    data = hexlify(randomBytes(1000))
    digest = keccak256(solidityPack(['bytes'], [data]))
  })

  it('should recovery address equal to signer address', async () => {
    const ec = new EC('secp256k1')
    const keypair = ec.keyFromPrivate(arrayify(`0x${PRIVATE_KEY}`))
    const signature = keypair.sign(arrayify(digest), { canonical: true })

    const spliceSig = splitSignature({
      recoveryParam: signature.recoveryParam,
      r: hexZeroPad('0x' + signature.r.toString(16), 32),
      s: hexZeroPad('0x' + signature.s.toString(16), 32)
    })

    const signatureHex = hexlify(
      concat([
        spliceSig.r,
        spliceSig.s,
        signature.recoveryParam ? '0x1c' : '0x1b'
      ])
    )
    const verify = await contract.verifyWithoutPrefix(digest, signatureHex)
    expect(verify).to.eq(true)
  })
})
