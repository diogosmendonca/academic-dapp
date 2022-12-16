import './App.css';
import { ethers } from "ethers";
import { useEffect, useState } from 'react';



function App() {
  const AcademicTokenAddr = "0x5FC8d32690cc91D4c39d9d3abcBD16989F875707"
  const AcademicTokenAbi = require('./AcademicToken.json')
  console.log(AcademicTokenAbi.abi);
  const [signer, setSigner] = useState()

  useEffect(() => {

    async function connect() {
      // A Web3Provider wraps a standard Web3 provider, which is
      // what MetaMask injects as window.ethereum into each page
      const provider = new ethers.providers.Web3Provider(window.ethereum)
  
      // MetaMask requires requesting permission to connect users accounts
      await provider.send("eth_requestAccounts", []);
  
      // The MetaMask plugin also allows signing transactions to
      // send ether and pay to change state within the blockchain.
      // For this, you need the account signer...
      const signer2 = provider.getSigner()
      console.log(signer2)

      const bn = await provider.getBlockNumber()
      console.log(bn);

      // The Contract object
      const academicContract = new ethers.Contract(AcademicTokenAddr, AcademicTokenAbi.abi, provider);
      console.log('--------------');
      console.log(await academicContract.balanceOf('0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266'));
      const academicContractWithSigner = academicContract.connect(signer2);
      console.log(await academicContractWithSigner.transfer('0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC', 1));
      console.log('--------------');
      setSigner(signer2);
    }
  
    connect();
  }, [])

  return (
    <p>{signer ? signer.address: ''}</p>
  );
}

export default App;
