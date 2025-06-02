import { NextResponse, NextRequest } from "next/server";

// eslint-disable-next-line @typescript-eslint/no-unused-vars
export function middleware(request: NextRequest) {
  return NextResponse.next();
}
