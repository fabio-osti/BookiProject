import { initializeApp, cert } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import serviceAccount from "./firebase-adminsdk.json" assert { type: "json" };

import * as readline from "node:readline/promises";
import { stdin as input, stdout as output } from "node:process";

const rl = readline.createInterface({ input, output });

async function setClaims(claim) {
	const email = await rl.question("User email: ");
	const user = (await getAuth().getUserByEmail(email)).uid;
	getAuth().setCustomUserClaims(user, claim);
}

initializeApp({
	credential: cert(serviceAccount),
});

const option = await rl.question(
	"Select an option:\n\t|1|. Add admin claim to an user.\n\t|2|. Remove admin claim from an user.\n\n> "
);
console.log(option);
switch (option) {
	case "1":
		await setClaims({ admin: true });
		break;

	case "2":
		await setClaims({});
		break;
}
process.exit()