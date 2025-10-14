import { sendTelegramMessage } from "@/lib/telegram";

export async function POST(req: Request) {
  const body = await req.json();

  if (body.message) {
    const chatId = body.message.chat.id;
    const text = body.message.text;

    if (text === "/register") {
      // await saveChatIdToDB(chatId, body.message.from.username);
      await sendTelegramMessage(
        chatId,
        "✅ Registered! You’ll now receive notifications."
      );
    } else {
      await sendTelegramMessage(chatId, text);
    }
  }

  return new Response("ok", { status: 200 });
}
