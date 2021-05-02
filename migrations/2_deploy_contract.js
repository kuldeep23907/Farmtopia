const fToken = artifacts.require("fToken");
const FarmtopiaInterface = artifacts.require("FarmtopiaInterface");

module.exports = function (deployer) {
    deployer.deploy(FarmtopiaInterface).then(function () {
      return deployer
        .deploy(fToken,"Farmtopia DAI", "fDAI", FarmtopiaInterface.address)
        .then(async function () {

            let fI =  await FarmtopiaInterface.deployed();

            await fI.setfDAI(
                fToken.address
              );
        });
    });
  };