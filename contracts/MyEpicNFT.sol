// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

// We first import some OpenZeppelin Contracts.
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

// We need to import the helper functions from the contract that we copy/pasted.
import { Base64 } from "../libraries/Base64.sol";

// We inherit the contract we imported. This means we'll have access
// to the inherited contract's methods.
contract MyEpicNFT is ERC721URIStorage {
  // Magic given to us by OpenZeppelin to help us keep track of tokenIds.
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

  // This is our SVG code. All we need to change is the word that's displayed. Everything else stays the same.
  // So, we make a baseSvg variable here that all our NFTs can use.
    string svgPartOne = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='";
    string svgPartTwo = "'/><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

  // I create three arrays, each with their own theme of random words.
  // Pick some random funny words, names of anime characters, foods you like, whatever! 
    string[] firstWords = ["Mexican", "Japanese", "Korean", "Albanian", "Belgian", "Vietnamese", "Sudanese", "Ethiopian", "Indian", "Pakistani", "Canadian", "Norwegian", "Turkish", "Greek", "Brazilian"];
    string[] secondWords = ["Turkey", "Salmon", "Cheetah", "Turtle", "Monkey", "Komodo Dragon", "Goldfish", "Pigeon", "Eagle", "Frog", "Tuna", "Dog", "Wolf", "Elephany", "Squirrel", "Lemur", "Copybara"];
    string[] thirdWords = ["Whistler", "Collecter", "Hoarder", "Worshipper", "Supplier", "Trader", "Denier", "Holder", "Hunter", "Cooker", "Inspector", "Respecter", "Breeder", "Hugger", "Lover", "Fighter"];

    // Declare colors
    string[] colors = ["#ad5b55", "#08C2A8", "#769636", "#ab4482", "#9356c4", "#4fa9f7", "#a9c1d6", "#baa66e", "#919463", "#deb4bd", "#a6eb88"];

    //  call logging event details from EVM *emit message later on*
    event NewEpicNFTMinted(address sender, uint256 tokenId);


  // We need to pass the name of our NFTs token and it's symbol.
    constructor() ERC721 ("SquareNFT", "SQUARE") {
    console.log("This is my NFT contract. Woah!");
    }

    // create function to randomly pick words from
    function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
        // seed random generator
        uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));
        // assign numbers with total length of array
        rand = rand % firstWords.length;
        return firstWords[rand];
    }

    // create function to randomly pick words from
    function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {
        // seed random generator
        uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
        rand = rand % secondWords.length;
        return secondWords[rand];
    }

    function pickRandomThirdWord(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
        rand = rand % thirdWords.length;
        return thirdWords[rand];
    }

    function pickRandomColor(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("COLOR", Strings.toString(tokenId))));
        rand = rand % colors.length;
        return colors[rand];
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

  // A function our user will hit to get their NFT.
    function makeAnEpicNFT() public {
     // Get the current tokenId, this starts at 0.
        uint256 newItemId = _tokenIds.current();

        // declare variable to call rand functions 
        string memory first = pickRandomFirstWord(newItemId);
        string memory second = pickRandomSecondWord(newItemId);
        string memory third = pickRandomThirdWord(newItemId);
        string memory combinedWord = string(abi.encodePacked(first, second, third));

        // Add color
        string memory randomColor = pickRandomColor(newItemId);

        // concat and close the <text> and <svg> tags
        string memory finalSVG = string(abi.encodePacked(svgPartOne, randomColor, svgPartTwo, combinedWord, "</text></svg>"));

        // Get all JSON metadata in 1 place and base64 encode
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // set title of NFT as generated word
                        combinedWord,
                        '", "description": "A highly acclaimed collection of squares", "image": "data:image/svg+xml;base64,',
                        // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                        Base64.encode(bytes(finalSVG)),
                        '"}'
                    )
                )
            )
        );

        // Just like before, we prepend data:application/json;base64, to our data.
        string memory finalTokenURI = string(
            abi.encodePacked("data:application/json;base64,", json)
        );


        console.log("\n--------------------");
        console.log(
            string(
                abi.encodePacked(
                    "https://nftpreview.0xdev.codes/?code=",
                    finalTokenURI
                )
            )
        );
        console.log("--------------------\n");


     // Actually mint the NFT to the sender using msg.sender.
        _safeMint(msg.sender, newItemId);

    // Set the NFTs data.
        _setTokenURI(newItemId, finalTokenURI);

    // Increment the counter for when the next NFT is minted.
        _tokenIds.increment();
        console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);

    //  emit message upon calling contract. send to frontend
    emit NewEpicNFTMinted(msg.sender, newItemId);
    }
}