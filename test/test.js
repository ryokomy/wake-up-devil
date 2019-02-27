const TenDaysWakeUpDevil = artifacts.require('TenDaysWakeUpDevil')

let baseTime
let snapshotId

function increaseTime(duration) {
    return new Promise((resolve, reject) => {
        web3.currentProvider.send({
            jsonrpc: '2.0',
            method: 'evm_increaseTime',
            params: [duration],
            id: Date.now(),
        }, err => {
            if (err) return reject(err)
            resolve()
        })
    })
}

function snapshotTime() {
    return new Promise((resolve, reject) => {
        web3.currentProvider.send({
            jsonrpc: '2.0',
            method: 'evm_snapshot',
            id: Date.now(),
        }, (err, res) => {
            if (err) return reject(err)
            resolve(res.result)
        })
    })
}

function revertTime() {
    return new Promise((resolve, reject) => {
        web3.currentProvider.send({
            jsonrpc: '2.0',
            method: 'evm_revert',
            params: [snapshotId],
            id: Date.now(),
        }, err => {
            if (err) return reject(err)
            resolve()
        })
    })
}

contract('TenDaysWakeUpDevil', async (accounts) => {

    const user = accounts[1]

    before(async () => {
        baseTime = Math.floor(new Date() / 1000)
        snapshotId = await snapshotTime()
    })

    after(async () => {
        await revertTime()
    })

    it('should register', async () => {
        const tenDaysWakeUpDevil = await TenDaysWakeUpDevil.deployed()

        // startAt = 7am next day
        let _now = new Date()
        let _startAt = new Date(`${_now.getFullYear()}/${_now.getMonth()+1}/${_now.getDate()+1} 07:00:00`)
        let startAt = Math.floor(_startAt / 1000)
        let tx = await tenDaysWakeUpDevil.register(
            startAt,
            {from: user, value: web3.utils.toWei(String(3), 'ether')}
        )

        let expectedWakeUpAts = []
        let expectedSuccesses = []
        for(let i=0; i<10; i++) {
            expectedWakeUpAts.push(String(startAt + 60*60*24 * i))
            expectedSuccesses.push(false)
        }

        // assert
        let result = await tenDaysWakeUpDevil.userAddressToWakeUpUnit(user)
        assert.equal(1, result.id)
        for(let i=0; i<10; i++) {
            assert.equal(expectedWakeUpAts[i], result.wakeUpAts[i])
            assert.equal(expectedSuccesses[i], result.successes[i])
        }
        assert.equal(true, result.exists)
    })

    it('should wakeup 1st day', async () => {
        const tenDaysWakeUpDevil = await TenDaysWakeUpDevil.deployed()

        let wakeUpUnit = await tenDaysWakeUpDevil.userAddressToWakeUpUnit(user)
        let firstWakeUpAt = wakeUpUnit.wakeUpAts[0]

        let _now = new Date()
        let now = Math.floor(_now / 1000)

        // set time forward
        let diff = firstWakeUpAt - now
        await increaseTime(diff)

        // wakeup
        let tx = await tenDaysWakeUpDevil.wakeUp(1, {from: user})

        // assert
        let result = await tenDaysWakeUpDevil.userAddressToWakeUpUnit(user)
        assert.equal(1, result.id)
        assert.equal(true, result.successes[0])
    })

    it('should wakeup last day', async () => {
        const tenDaysWakeUpDevil = await TenDaysWakeUpDevil.deployed()

        // set time forward
        await increaseTime(60 * 60 * 24 * 9)

        // wakeup
        let tx = await tenDaysWakeUpDevil.wakeUp(10, {from: user})

        // assert
        let result = await tenDaysWakeUpDevil.userAddressToWakeUpUnit(user)
        assert.equal(1, result.id)
        assert.equal(true, result.successes[9])
    })

})