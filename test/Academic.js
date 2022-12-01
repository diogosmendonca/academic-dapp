const { expect } = require("chai");
const {
    loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");

describe("Academic", function () {

    async function deployContracts() {
        const AcademicUtils = await hre.ethers.getContractFactory("AcademicUtils");
        const academicUtils = await AcademicUtils.deploy();
        await academicUtils.deployed();
        console.log(
            `AcademicUtils contract deployed to ${academicUtils.address}`
        );

        const Academic = await hre.ethers.getContractFactory("Academic", {
            libraries: {
            AcademicUtils: academicUtils.address,
            },
        });
        const academic = await Academic.deploy();
        await academic.deployed();

        console.log(
            `Academic contract deployed to ${academic.address}`
        );

        const AlunoContract = await hre.ethers.getContractFactory("AlunoContract");
        const alunoContract = await AlunoContract.deploy(academic.address);
        await alunoContract.deployed();
        console.log(
            `AlunoContract contract deployed to ${alunoContract.address}`
        );

        const result = await academic.setAlunoContractAddress(alunoContract.address);
        await result.wait(1);
        console.log(
            `Deploy finished with success!`
        );

        return {academic, alunoContract};
    }



    describe("Academic Contract", function () {

        it("Inserir Aluno should revert for a discipline without a professor", async function () {
            const { academic } = await loadFixture(deployContracts);

            await expect(academic.inserirNota(0, 0, 0)).to.be.revertedWith(
                "Disciplina sem professor"
            );
        });

        it("Should a professor be able to insert a grade", async function () {
            const { academic, alunoContract } = await loadFixture(deployContracts);
            const [owner, professor, otherAccount] = await hre.ethers.getSigners();

            await academic.inserirDisciplina(1, "Blockchain", professor.address);
            await alunoContract.inserirAluno(1, "Diogo");
            await academic.abrirLancamentoNota();
            await academic.connect(professor).inserirNota(1, 1, 8);
            const [alunos, notas] = await academic.listarNotasDisciplina(1);
            expect(alunos[0].nome).to.equal("Diogo");
            expect(notas[0]).to.equal(8);

        });


        

    });

    describe("Aluno Contract", function () {

        it("Should register a valid student", async function () {
            const { alunoContract } = await loadFixture(deployContracts);

            await alunoContract.inserirAluno(1, "Diogo");
            const aluno = await alunoContract.getAlunoById(1);
            expect(aluno.nome).to.equal("Diogo");
            expect(aluno.id).to.equal(1)
        });

    });

});