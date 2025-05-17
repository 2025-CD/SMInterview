package sm.ac.app.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import sm.ac.app.dto.UsersDto;
import sm.ac.app.frame.InterviewService;
import sm.ac.app.repository.UsersRepository;

import java.util.List;

@Service
@RequiredArgsConstructor
public class UsersService implements InterviewService<String, UsersDto> {
    //인터페이스가 될 수 없다.
    //보통 controller가 호출하기 때문.
    //RequiredArgsConstructor를 써주면 CustService 객체가 생성될때 자동으로 custRepository 생성
    //RequiredArgsContructor를 사용하면, 필드를 final로..
    final UsersRepository usersRepository;

    @Override
    public void add(UsersDto usersDto) throws Exception {
        usersRepository.insert(usersDto);



    }

    @Override
    public void modify(UsersDto usersDto) throws Exception {
        usersRepository.update(usersDto);


    }

    @Override
    public void del(String s) throws Exception {
        usersRepository.delete(s);

    }

    @Override
    public UsersDto get(String s) throws Exception {
        return usersRepository.selectOne(s);
    }

    @Override
    public List<UsersDto> get() throws Exception {
        return usersRepository.select();
    }

    public int getMentorCountByJobField(int jobfieldid) {
        return usersRepository.countMentorsByJobField(jobfieldid);
    }







}
