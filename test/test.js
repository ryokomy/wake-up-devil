const TenDaysWakeUpDevil = artifacts.require('TenDaysWakeUpDevil')

contract('TenDaysWakeUpDevil', async (accounts) => {

    const user = accounts[1]

    it('should register', async () => {
        const tenDaysWakeUpDevil = await TenDaysWakeUpDevil.deployed()

        // startAt = 7am next day
        let _now = new Date()
        let _startAt = new Date(`${_now.getFullYear()}/${_now.getMonth()+1}/${_now.getDate()+1} 07:00:00`)
        let startAt = Math.floor(_startAt / 1000)
        await tenDaysWakeUpDevil.register(
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
        let result = await tenDaysWakeUpDevil.userAddressToWakeUps(user)
        assert.equal(1, result.userId)
        assert.equal(0, result.successCount)
        assert.equal(0, result.withdrawCount)
        for(let i=0; i<10; i++) {
            assert.equal(expectedWakeUpAts[i], result.wakeUpAts[i])
            assert.equal(expectedSuccesses[i], result.successes[i])
        }
        assert.equal(true, result.exists)
    })

})