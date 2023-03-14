import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-foundry";
import "tsconfig-paths/register";

const config: HardhatUserConfig = {
  solidity: "0.8.17",
};

export default config;
